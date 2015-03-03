/*
 * Copyright 2002-2013 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.jruby.rack.mock;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Collections;
import java.util.EnumSet;
import java.util.Enumeration;
import java.util.EventListener;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;
import javax.activation.FileTypeMap;
import javax.servlet.Filter;
import javax.servlet.FilterRegistration;
import javax.servlet.RequestDispatcher;
import javax.servlet.Servlet;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRegistration;
import javax.servlet.SessionCookieConfig;
import javax.servlet.SessionTrackingMode;
import javax.servlet.descriptor.JspConfigDescriptor;

import org.springframework.core.io.DefaultResourceLoader;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;

import org.jruby.rack.RackLogger;
import static org.jruby.rack.RackLogger.*;

/**
 * Mock implementation of the {@link javax.servlet.ServletContext} interface.
 *
 * <p>As of Spring 4.0, this set of mocks is designed on a Servlet 3.0 baseline.
 *
 * <p>Compatible with Servlet 3.0 but can be configured to expose a specific version
 * through {@link #setMajorVersion}/{@link #setMinorVersion}; default is 3.0.
 * Note that Servlet 3.0 support is limited: servlet, filter and listener
 * registration methods are not supported; neither is JSP configuration.
 * We generally do not recommend to unit-test your ServletContainerInitializers and
 * WebApplicationInitializers which is where those registration methods would be used.
 *
 * <p>Used for testing the Spring web framework; only rarely necessary for testing
 * application controllers. As long as application components don't explicitly
 * access the {@code ServletContext}, {@code ClassPathXmlApplicationContext} or
 * {@code FileSystemXmlApplicationContext} can be used to load the context files
 * for testing, even for {@code DispatcherServlet} context definitions.
 *
 * <p>For setting up a full {@code WebApplicationContext} in a test environment,
 * you can use {@code AnnotationConfigWebApplicationContext},
 * {@code XmlWebApplicationContext}, or {@code GenericWebApplicationContext},
 * passing in an appropriate {@code MockServletContext} instance. You might want
 * to configure your {@code MockServletContext} with a {@code FileSystemResourceLoader}
 * in that case to ensure that resource paths are interpreted as relative filesystem
 * locations.
 *
 * <p>A common setup is to point your JVM working directory to the root of your
 * web application directory, in combination with filesystem-based resource loading.
 * This allows to load the context files as used in the web application, with
 * relative paths getting interpreted correctly. Such a setup will work with both
 * {@code FileSystemXmlApplicationContext} (which will load straight from the
 * filesystem) and {@code XmlWebApplicationContext} with an underlying
 * {@code MockServletContext} (as long as the {@code MockServletContext} has been
 * configured with a {@code FileSystemResourceLoader}).
 *
 * @author Rod Johnson
 * @author Juergen Hoeller
 * @author Sam Brannen
 */
public class MockServletContext implements ServletContext {

	private static final String TEMP_DIR_SYSTEM_PROPERTY = "java.io.tmpdir";

    private static final String TEMP_DIR_CONTEXT_ATTRIBUTE = "javax.servlet.context.tempdir";

	private final ResourceLoader resourceLoader;

	private final String resourceBasePath;

	private String contextPath = "";

	private int majorVersion = 3;
	private int minorVersion = 0;

	private int effectiveMajorVersion = 3;
	private int effectiveMinorVersion = 0;

	private final Map<String, ServletContext> contexts = new HashMap<String, ServletContext>();
	private final Map<String, String> initParameters = new LinkedHashMap<String, String>();
	private final Map<String, Object> attributes = new LinkedHashMap<String, Object>();

	private String servletContextName = "MockServletContext";
    //private String defaultServletName = "default";

	//final Map<String, RequestDispatcher> namedRequestDispatchers = new HashMap<String, RequestDispatcher>();

	private final Set<String> declaredRoles = new HashSet<String>();

	private Set<SessionTrackingMode> sessionTrackingModes;

	private Object sessionCookieConfig; // SessionCookieConfig

    private RackLogger logger = new NullLogger();

	/**
	 * Create a new MockServletContext, using no base path and a
	 * DefaultResourceLoader (i.e. the classpath root as WAR root).
	 * @see org.springframework.core.io.DefaultResourceLoader
	 */
	public MockServletContext() {
		this("", null);
	}

	/**
	 * Create a new MockServletContext, using a DefaultResourceLoader.
	 * @param resourceBasePath the WAR root directory (should not end with a slash)
	 * @see org.springframework.core.io.DefaultResourceLoader
	 */
	public MockServletContext(String resourceBasePath) {
		this(resourceBasePath, null);
	}

	/**
	 * Create a new MockServletContext, using the specified ResourceLoader
	 * and no base path.
	 * @param resourceLoader the ResourceLoader to use (or null for the default)
	 */
	MockServletContext(ResourceLoader resourceLoader) {
		this("", resourceLoader);
	}

	/**
	 * Create a new MockServletContext.
	 * @param resourceBasePath the WAR root directory (should not end with a slash)
	 * @param resourceLoader the ResourceLoader to use (or null for the default)
	 */
	MockServletContext(String resourceBasePath, ResourceLoader resourceLoader) {
		this.resourceLoader = (resourceLoader != null ? resourceLoader : new DefaultResourceLoader());
		this.resourceBasePath = (resourceBasePath != null ? resourceBasePath : "");

		// Use JVM temp dir as ServletContext temp dir.
		String tempDir = System.getProperty(TEMP_DIR_SYSTEM_PROPERTY);
		if (tempDir != null) {
			this.attributes.put(TEMP_DIR_CONTEXT_ATTRIBUTE, new File(tempDir));
		}
	}


	/**
	 * Build a full resource location for the given path,
	 * prepending the resource base path of this MockServletContext.
	 * @param path the path as specified
	 * @return the full resource path
	 */
	protected String getResourceLocation(String path) {
		if (!path.startsWith("/")) {
			path = "/" + path;
		}
		return this.resourceBasePath + path;
	}

    private static class NullLogger extends RackLogger.Base {

        @Override
        public void log(String message) { /* NOOP */ }

        @Override
        public void log(String message, Throwable ex) { /* NOOP */ }

        @Override
        public boolean isEnabled(Level level) { return false; }

        @Override
        public void log(Level level, String message) { /* NOOP */ }

        @Override
        public void log(Level level, String message, Throwable ex) { /* NOOP */ }

        @Override
        public Level getLevel() { return null; }

    }

	public void setContextPath(String contextPath) {
		this.contextPath = (contextPath != null ? contextPath : "");
	}

    @Override // Servlet API 2.5
	public String getContextPath() {
		return this.contextPath;
	}

	public void registerContext(String contextPath, ServletContext context) {
		this.contexts.put(contextPath, context);
	}

    @Override
	public ServletContext getContext(String contextPath) {
		if (this.contextPath.equals(contextPath)) {
			return this;
		}
		return this.contexts.get(contextPath);
	}

	public void setMajorVersion(int majorVersion) {
		this.majorVersion = majorVersion;
	}

    @Override
	public int getMajorVersion() {
		return this.majorVersion;
	}

	public void setMinorVersion(int minorVersion) {
		this.minorVersion = minorVersion;
	}

    @Override
	public int getMinorVersion() {
		return this.minorVersion;
	}

	public void setEffectiveMajorVersion(int effectiveMajorVersion) {
		this.effectiveMajorVersion = effectiveMajorVersion;
	}

    @Override

    public int getEffectiveMajorVersion() {
		return this.effectiveMajorVersion;
	}

	public void setEffectiveMinorVersion(int effectiveMinorVersion) {
		this.effectiveMinorVersion = effectiveMinorVersion;
	}

    @Override
	public int getEffectiveMinorVersion() {
		return this.effectiveMinorVersion;
	}

    @Override
	public String getMimeType(String filePath) {
		return MimeTypeResolver.getMimeType(filePath);
	}

    @Override
	public Set<String> getResourcePaths(String path) {
		String actualPath = (path.endsWith("/") ? path : path + "/");
		Resource resource = this.resourceLoader.getResource(getResourceLocation(actualPath));
		try {
			File file = resource.getFile();
			String[] fileList = file.list();
			if (fileList == null || fileList.length == 0) {
				return null;
			}
			Set<String> resourcePaths = new LinkedHashSet<String>(fileList.length);
			for (String fileEntry : fileList) {
				String resultPath = actualPath + fileEntry;
				if (resource.createRelative(fileEntry).getFile().isDirectory()) {
					resultPath += "/";
				}
				resourcePaths.add(resultPath);
			}
			return resourcePaths;
		}
		catch (IOException ex) {
			logger.log(WARN, "Couldn't get resource paths for " + resource, ex);
			return null;
		}
	}

    @Override
	public URL getResource(String path) throws MalformedURLException {
		Resource resource = this.resourceLoader.getResource(getResourceLocation(path));
		if (!resource.exists()) {
			return null;
		}
		try {
			return resource.getURL();
		}
		catch (MalformedURLException ex) {
			throw ex;
		}
		catch (IOException ex) {
			logger.log(WARN, "Couldn't get URL for " + resource, ex);
			return null;
		}
	}

    @Override
	public InputStream getResourceAsStream(String path) {
		Resource resource = this.resourceLoader.getResource(getResourceLocation(path));
		if (!resource.exists()) {
			return null;
		}
		try {
			return resource.getInputStream();
		}
		catch (IOException ex) {
			logger.log(WARN, "Couldn't open InputStream for " + resource, ex);
			return null;
		}
	}

    @Override
	public RequestDispatcher getRequestDispatcher(String path) {
		if (!path.startsWith("/")) {
			throw new IllegalArgumentException("RequestDispatcher path at ServletContext level must start with '/'");
		}
		return new MockRequestDispatcher(path);
	}

    @Override
	public RequestDispatcher getNamedDispatcher(String path) {
		return null;
	}

    @Override @SuppressWarnings("deprecation")
	public Servlet getServlet(String name) {
		return null;
	}

    @Override
	public Enumeration<Servlet> getServlets() {
		return Collections.enumeration(new HashSet<Servlet>());
	}

    @Override @SuppressWarnings("deprecation")
	public Enumeration<String> getServletNames() {
		return Collections.enumeration(new HashSet<String>());
	}

    @Override
	public void log(String message) {
		logger.log(message);
	}

    @Override @SuppressWarnings("deprecation")
	public void log(Exception ex, String message) {
		logger.log(message, ex);
	}

    @Override
	public void log(String message, Throwable ex) {
		logger.log(message, ex);
	}

    public RackLogger getLogger() {
        return (logger instanceof NullLogger) ? null : logger;
    }

    public void setLogger(RackLogger logger) {
        this.logger = logger == null ? new NullLogger() : logger;
    }

    @Override
	public String getRealPath(String path) {
		Resource resource = this.resourceLoader.getResource(getResourceLocation(path));
		try {
			return resource.getFile().getAbsolutePath();
		}
		catch (IOException ex) {
			logger.log(WARN, "Couldn't determine real path of resource " + resource, ex);
			return null;
		}
	}

    @Override
	public String getServerInfo() {
		return "MockServletContext";
	}

    @Override
	public String getInitParameter(String name) {
        if (name == null) {
            throw new IllegalArgumentException("parameter name must not be null");
        }
		return this.initParameters.get(name);
	}

	public void addInitParameter(String name, String value) {
        if (name == null) {
            throw new IllegalArgumentException("parameter name must not be null");
        }
		this.initParameters.put(name, value);
	}

    @Override
	public Enumeration<String> getInitParameterNames() {
		return Collections.enumeration(this.initParameters.keySet());
	}

    @Override
	public Object getAttribute(String name) {
        if (name == null) {
            throw new IllegalArgumentException("attribute name must not be null");
        }
		return this.attributes.get(name);
	}

    @Override
	public Enumeration<String> getAttributeNames() {
		return Collections.enumeration(this.attributes.keySet());
	}

    @Override
	public void setAttribute(String name, Object value) {
        if (name == null) {
            throw new IllegalArgumentException("attribute name must not be null");
        }
		if (value != null) {
			this.attributes.put(name, value);
		}
		else {
			this.attributes.remove(name);
		}
	}

    @Override
	public void removeAttribute(String name) {
        if (name == null) {
            throw new IllegalArgumentException("attribute name must not be null");
        }
		this.attributes.remove(name);
	}

	public void setServletContextName(String servletContextName) {
		this.servletContextName = servletContextName;
	}

    @Override
	public String getServletContextName() {
		return this.servletContextName;
	}


	/**
	 * Inner factory class used to just introduce a Java Activation Framework
	 * dependency when actually asked to resolve a MIME type.
	 */
	private static class MimeTypeResolver {

		public static String getMimeType(String filePath) {
			return FileTypeMap.getDefaultFileTypeMap().getContentType(filePath);
		}

	}


	//---------------------------------------------------------------------
	// Methods introduced in Servlet 3.0
	//---------------------------------------------------------------------

	@Override
	public ClassLoader getClassLoader() {
		// return ClassUtils.getDefaultClassLoader();
		ClassLoader cl = null;
		try {
			cl = Thread.currentThread().getContextClassLoader();
		}
		catch (Exception ex) {
			// Cannot access thread context ClassLoader - falling back...
		}
		if (cl == null) {
			// No thread context class loader -> use class loader of this class.
			cl = MockServletContext.class.getClassLoader();
			if (cl == null) {
				// getClassLoader() returning null indicates the bootstrap ClassLoader
				try {
					cl = ClassLoader.getSystemClassLoader();
				}
				catch (Exception ex) {
					// Cannot access system ClassLoader - oh well, maybe the caller can live with null...
				}
			}
		}
		return cl;
	}

	@Override
	public void declareRoles(String... roleNames) {
		// Assert.notNull(roleNames, "Role names array must not be null");
		for (String roleName : roleNames) {
			// Assert.hasLength(roleName, "Role name must not be empty");
			this.declaredRoles.add(roleName);
		}
	}

	public Set<String> getDeclaredRoles() {
		return Collections.unmodifiableSet(this.declaredRoles);
	}

	@Override
	public boolean setInitParameter(String name, String value) {
		// Assert.notNull(name, "Parameter name must not be null");
		if (this.initParameters.containsKey(name)) {
			return false;
		}
		this.initParameters.put(name, value);
		return true;
	}

	@Override
	public void setSessionTrackingModes(Set<SessionTrackingMode> sessionTrackingModes)
			throws IllegalStateException, IllegalArgumentException {
		this.sessionTrackingModes = sessionTrackingModes;
	}

	@Override
	public Set<SessionTrackingMode> getDefaultSessionTrackingModes() {
        return EnumSet.of(SessionTrackingMode.COOKIE, SessionTrackingMode.URL, SessionTrackingMode.SSL);
	}

	@Override
	public Set<SessionTrackingMode> getEffectiveSessionTrackingModes() {
		return (this.sessionTrackingModes != null ?
            Collections.unmodifiableSet(this.sessionTrackingModes) : getDefaultSessionTrackingModes());
	}

	@Override
	public SessionCookieConfig getSessionCookieConfig() {
        if (sessionCookieConfig == null) {
            sessionCookieConfig = new MockSessionCookieConfig();
        }
		return (SessionCookieConfig) sessionCookieConfig;
	}

	//---------------------------------------------------------------------
	// Unsupported Servlet 3.0 registration methods
	//---------------------------------------------------------------------

	@Override
	public JspConfigDescriptor getJspConfigDescriptor() {
		throw new UnsupportedOperationException();
	}

	@Override
	public ServletRegistration.Dynamic addServlet(String servletName, String className) {
		throw new UnsupportedOperationException();
	}

	@Override
	public ServletRegistration.Dynamic addServlet(String servletName, Servlet servlet) {
		throw new UnsupportedOperationException();
	}

	@Override
	public ServletRegistration.Dynamic addServlet(String servletName, Class<? extends Servlet> servletClass) {
		throw new UnsupportedOperationException();
	}

	@Override
	public <T extends Servlet> T createServlet(Class<T> c) throws ServletException {
		throw new UnsupportedOperationException();
	}

	@Override
	public ServletRegistration getServletRegistration(String servletName) {
		throw new UnsupportedOperationException();
	}

	@Override
	public Map<String, ? extends ServletRegistration> getServletRegistrations() {
		throw new UnsupportedOperationException();
	}

	@Override
	public FilterRegistration.Dynamic addFilter(String filterName, String className) {
		throw new UnsupportedOperationException();
	}

	@Override
	public FilterRegistration.Dynamic addFilter(String filterName, Filter filter) {
		throw new UnsupportedOperationException();
	}

	@Override
	public FilterRegistration.Dynamic addFilter(String filterName, Class<? extends Filter> filterClass) {
		throw new UnsupportedOperationException();
	}

	@Override
	public <T extends Filter> T createFilter(Class<T> c) throws ServletException {
		throw new UnsupportedOperationException();
	}

	@Override
	public FilterRegistration getFilterRegistration(String filterName) {
		throw new UnsupportedOperationException();
	}

	@Override
	public Map<String, ? extends FilterRegistration> getFilterRegistrations() {
		throw new UnsupportedOperationException();
	}

	@Override
	public void addListener(Class<? extends EventListener> listenerClass) {
		throw new UnsupportedOperationException();
	}

	@Override
	public void addListener(String className) {
		throw new UnsupportedOperationException();
	}

	@Override
	public <T extends EventListener> void addListener(T t) {
		throw new UnsupportedOperationException();
	}

	@Override
	public <T extends EventListener> T createListener(Class<T> c) throws ServletException {
		throw new UnsupportedOperationException();
	}

}
